require 'json'
require 'yaml'
require 'active_record'
require 'composite_primary_keys'
require 'benchmark'

config = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(config)

class Account < ActiveRecord::Base
    has_many :items

    self.primary_key = 'id'
end
  
class Charge < ActiveRecord::Base
    belongs_to :account
  
    self.primary_keys = 'region', 'id'
end

# GET /accounts
def list_accounts(event:, context:)
    authenticate(event['headers']) do |account|
        {
            statusCode: 200,
            body: account_result(account).to_json
        }
    end
end

# GET /charges
def list_charges(event:, context:)
    authenticate(event['headers']) do |account|
        limit = param(event['queryStringParameters'], 'limit')
        if !limit
          limit = 100
        end
        charges = Charge.where(account_id: account.id).order(created_at: :desc).limit(limit)
        {
            statusCode: 200,
            body: charges.map { |c| charge_result(c) }.to_json
        }
    end
end

# GET /charges/{id}
def get_charge(event:, context:)
    authenticate(event['headers']) do |account|
        id = param(event['pathParameters'], 'id')

        # Start by assuming charge is in the current region, for fast lookup.
        charge = Charge.
          where("region = crdb_internal.locality_value('region')").
          where(id: id).
          where(account_id: account.id).
          first
    
        if !charge
          # Charge not in current region, so search all regions for it.
          puts "checking all regions"
          charge = Charge.where(id: id).where(account_id: account.id).first
        end
    
        if charge
            {
                statusCode: 200,
                body: charge_result(charge).to_json
            }
        else
            {
                statusCode: 404,
            }
        end
    end
end

# POST /charges
def create_charge(event:, context:)
    authenticate(event['headers']) do |account|
        params = post_body(event['body'])
        create_params = {
            account_id: account.id,
            last4: params[:card_number][-4..-1],
            amount: params[:amount],
            currency: params[:currency]
        }
        charge = Charge.create!(create_params)

        # This is where the issuer would be contacted to authorize the charge.

        # Pretend that if last digit of card is even, then charge would be always be
        # authorized. If odd, it's declined.
        if create_params[:last4].to_i % 2 == 0
            charge.outcome = 'authorized'
        else
            charge.outcome = 'issuer_declined'
        end
        charge.save!

        {
            statusCode: 201,
            body: charge_result(charge).to_json
        }
    end
end

def authenticate(headers, &on_authenticated)
    if !headers.key?('Authorization')
        return access_denied('no secret key was supplied')
    end

    auth = Base64.decode64(headers['Authorization'].split(' ', 2).last || '')
    secret_key_digest = Digest::SHA256.base64digest(auth)
    account = Account.where(secret_key_digest: secret_key_digest).first
    if !account
        return access_denied('secret key does not match any account')
    end

    on_authenticated.call(account)
end

def post_body(body)
    params = {}
    body.split('&').each do |param|
        vals = param.split('=')
        params[vals[0].to_sym] = vals[1]
    end
    params
end

def param(params, name)
    if params
        params[name]
    end
end

def account_result(account)
    {
        id: account.id,
        email: account.email,
        created_at: account.created_at,
    }
end

def charge_result(charge)
    {
        region: charge.region,
        id: charge.id[1],
        amount: charge.amount,
        currency: charge.currency,
        last4: charge.last4,
        outcome: charge.outcome,
        created_at: charge.created_at,
    }
end

def access_denied(reason)
    {
        statusCode: 401,
        body: 'Access Denied: ' + reason
    }
end

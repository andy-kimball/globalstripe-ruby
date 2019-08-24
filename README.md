# README

Payments is a demo showing how easy it could be to build a global application
using CRDB.

## How to Setup

*Local cluster*

./cockroach start --insecure --locality="cloud=aws,region=us-east-2,zone=us-east-2a" --store=node1 --listen-addr=localhost:26257 --http-addr=localhost:8080
./cockroach start --insecure --locality="cloud=aws,region=eu-west-3,zone=eu-west-3a" --store=node2 --listen-addr=localhost:26258 --http-addr=localhost:8081 --join=localhost:26257
./cockroach start --insecure --locality="cloud=aws,region=ap-northeast-2,zone=ap-northeast-2a" --store=node3 --listen-addr=localhost:26259 --http-addr=localhost:8082 --join=localhost:26257

*Cloud cluster (mimics future entry-level MSO cluster)*
1. export CLUSTER=andyk-test
2. roachprod create $CLUSTER -n 3 --aws-zones="us-east-2a,eu-west-3a,ap-northeast-2a" --geo --clouds=aws
3. roachprod stage $CLUSTER cockroach
4. roachprod start $CLUSTER --secure

*Create schema*
Run schema.sql on the newly created cluster.

*Create and deploy Ruby libraries and application using Serverless*
Install Node v6 or higher
npm install -g serverless
./build.sh
sls deploy

## How to Run
Some default accounts are already populated by the SQL script.

*List accounts*

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/accounts -u sk_test_L1K7x6igR9CBDGMkEcyvZJRf: 2>/dev/null | json_pp | pygmentize -l json -f terminal256 -O style=emacs

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/accounts -u sk_test_5QqJZz3BQRRYcvJqW7FchfIG: -w "\n\n%{time_starttransfer} seconds\n" 2>/dev/null

*Create some charges*

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges -u sk_test_L1K7x6igR9CBDGMkEcyvZJRf: -d amount=100.00 -d currency=USD -d card_number=4242424242424242 2>/dev/null | json_pp | pygmentize -l json -f terminal256 -O style=emacs

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges -u sk_test_5QqJZz3BQRRYcvJqW7FchfIG: -d amount=25.39 -d currency=USD -d card_number=4242424242424242 2>/dev/null | json_pp | pygmentize -l json -f terminal256 -O style=emacs

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges -u sk_test_5QqJZz3BQRRYcvJqW7FchfIG: -d amount=10.00 -d currency=USD -d card_number=4242424242424242 -w "\n\n%{time_starttransfer} seconds\n" 2>/dev/null

*List all charges for a user*
curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges -u sk_test_5QqJZz3BQRRYcvJqW7FchfIG: 2>/dev/null | json_pp | pygmentize -l json -f terminal256 -O style=emacs

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges -u sk_test_L1K7x6igR9CBDGMkEcyvZJRf: -w "\n\n%{time_starttransfer} seconds\n" 2>/dev/null 2>/dev/null

*List one charge for a user*
curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges/f48dcf9d-59ae-4035-a19b-83f23dc90cce -u sk_test_L1K7x6igR9CBDGMkEcyvZJRf: 2>/dev/null | json_pp | pygmentize -l json -f terminal256 -O style=emacs

curl https://x2ahsqbe5e.execute-api.us-east-2.amazonaws.com/v1/charges/f48dcf9d-59ae-4035-a19b-83f23dc90cce -u sk_test_L1K7x6igR9CBDGMkEcyvZJRf: -w "\n\n%{time_starttransfer} seconds\n" 2>/dev/null
FROM lambci/lambda:build-ruby2.5

RUN yum install -y postgresql postgresql-devel mysql mysql-devel
RUN gem update bundler

ADD Gemfile /var/task/Gemfile
ADD Gemfile.lock /var/task/Gemfile.lock

RUN bundle install --path /var/task/vendor/bundle --clean
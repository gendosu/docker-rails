#Railsですが、フロントエンドにVueとかReactを使って表示するようにするオプションがあり、それを有効にするとRailsの通常の実行時にnodeが必要になる
FROM node:8.9.4-alpine as node
FROM ruby:2.7.0-alpine
# 依存関係のあるパッケージのinstall
# gccやgitなど、ビルドに必要なものもすべて含まれている
RUN apk --update --no-cache add shadow sudo busybox-suid mariadb-connector-c-dev tzdata alpine-sdk
RUN mkdir -p /rails
WORKDIR /rails
#COPY Gemfile Gemfile.lock ./
# node
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt/yarn /opt/yarn
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs && \    ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \    ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn
# bundle install
# RUN gem install bundler --version 1.17.3 && \
#     bundle install --jobs 4
# assets precompile(トランスパイルをかけるため） #可能な限りステップ毎のキャッシュが使われるようにする
# COPY Rakefile ./
# COPY app/ app/
# COPY bin bin
# COPY config config
# COPY vendor/assets vendor/assets
# RUN bundle exec rails assets:precompile
# パッケージ全体を軽量化して、railsが起動する最低限のものにする
RUN apk --update --no-cache add shadow sudo busybox-suid execline tzdata mariadb-connector-c-dev && \    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
EXPOSE 80
# gemやassets:precompileの終わったファイルはbuilderからコピーしてくる
# COPY --from=builder /rails/vendor/bundle vendor/bundle
# COPY --from=builder /rails/public public
# COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . /rails
CMD exec bundle exec puma -p 80 -e "$RAILS_ENV" -C config/puma.rb

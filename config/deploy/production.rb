# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{ubuntu@production.softwearcrm.com}
# role :web, %w{ubuntu@production.softwearcrm.com}
# role :db,  %w{ubuntu@production.softwearcrm.com}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

set :branch, 'master'

server '50.19.126.7',    user: 'ubuntu', roles: %w{web app redis} # , my_property: :my_value
server '54.221.198.113', user: 'ubuntu', roles: %w{web app db}
server '54.197.100.175',  user: 'ubuntu', roles: %w{web} # , my_property: :my_value

set :linked_files, fetch(:linked_files) + %w{config/sidekiq.yml}

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'production.softwearcrm.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }

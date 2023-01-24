require_relative "user/organization"
require_relative "user/project"
require_relative "user/user"
require_relative "user/public_user"
require_relative "utils/api"
require_relative "utils/cache"
require_relative "utils/case"
require_relative "utils/checks"
require_relative "utils/enum"
require_relative "utils/host"
require_relative "utils/parse"
require_relative "utils/request"
require_relative "utils/resource"
require_relative "utils/rest"
require_relative "utils/sub_resource"
require_relative "utils/url"
require_relative "environment"
require_relative "error"
require_relative "key"

module StarkCore
    @user = nil
    @language = 'en-US'
    class << self; attr_accessor :user, :language; end
end

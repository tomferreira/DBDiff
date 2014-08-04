require 'checker'

namespace :dbdiff do

    desc "Check changes in databases"
    task :check do
        Checker.new
    end

end

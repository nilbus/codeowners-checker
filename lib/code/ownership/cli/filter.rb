# frozen_string_literal: true

require_relative '../checker'
require_relative 'base'

# frozen_string_literal: true
module Code
  module Ownership
    module Cli
      class Filter < Base
        option :from, default: 'origin/master'
        option :to, default: 'HEAD'
        option :verbose, default: false, type: :boolean, aliases: '-v'
        desc 'by <owner>', <<~DESC
          Lists changed files owned by TEAM.
          If no team is specified, default team is taken from .default_team.
        DESC
        # option :local, default: false, type: :boolean, aliases: '-l'
        # option :branch, default: '', aliases: '-b'
        def by(team_name = config.default_team)
          return if team_name.nil?

          changes = checker.changes_with_ownership(team_name)
          if changes.key?(team_name)
            changes.values.each { |file| puts file }
          else
            puts "Owner #{team_name} not defined in .github/CODEOWNERS"
          end
        end

        option :from, default: 'origin/master'
        option :to, default: 'HEAD'
        option :verbose, default: false, type: :boolean, aliases: '-v'
        desc 'all', 'Lists all changed files grouped by owner'
        def all
          changes = checker.changes_with_ownership.select { |_owner, val| val && !val.empty? }
          changes.keys.each do |owner|
            puts(owner + ":\n  " + changes[owner].join("\n  ") + "\n\n")
          end
        end

        def initialize(args = [], options = {}, config = {})
          super
          @repo_base_path = `git rev-parse --show-toplevel`
          if !@repo_base_path || @repo_base_path.empty?
            raise 'You must be positioned in a git repository to use this tool'
          end

          @repo_base_path.chomp!
          Dir.chdir(@repo_base_path)

          @checker ||= config[:checker] || default_checker
        end

        default_task :by

        private

        attr_reader :checker

        def default_checker
          Code::Ownership::Checker.new(@repo_base_path, options[:from], options[:to])
        end
      end
    end
  end
end

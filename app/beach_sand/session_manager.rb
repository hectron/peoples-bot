require "set"
require "redis"

module BeachSand
  class SessionManager
    class BadTimeout < StandardError; end

    MaxTimeoutAllowed = 60 * 60 # 1 hour, in seconds
    MinTimeoutAllowed = 60 # 1 minute, in seconds
    InsertOk = "OK".freeze

    class << self
      def acquire_lock(lock_name, timeout: nil)
        if redis_enabled?
          raise BadTimeout, "Timeout must be provided (in seconds)" if timeout.nil?
          raise BadTimeout, "Timeout must be at least #{MinTimeoutAllowed} seconds" if timeout < MinTimeoutAllowed
          raise BadTimeout, "Timeout must be at most #{MaxTimeoutAllowed} seconds" if timeout > MaxTimeoutAllowed

          redis_client.set(lock_name, "locked for a total of #{timeout} seconds", ex: timeout) == InsertOk
        else
          !!session_store.add?(lock_name)
        end
      end

      def release_lock(lock_name)
        if redis_enabled?
          redis_client.del(lock_name) == 1
        else
          !!session_store.delete?(lock_name)
        end
      end

      def release_all!
        !!session_store.clear
      end

      private

      def session_store
        @session_store ||= Set.new([])
      end

      def redis_enabled?
        @redis_enabled ||= !ENV.fetch("REDIS_URL", "").empty?
      end

      def redis_client
        @redis_client ||= Redis.new(url: ENV["REDIS_URL"]) if redis_enabled?
      end
    end
  end
end

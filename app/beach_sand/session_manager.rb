require "set"
require "redlock"

module BeachSand
  class SessionManager
    class BadTimeout < StandardError; end

    MaxTimeoutAllowed = 1_000 * 60 * 60 # 1 hour, in milliseconds
    MinTimeoutAllowed = 1_000 * 60 # 1 minute, in milliseconds

    class << self
      def acquire_lock(lock_name, timeout: nil)
        if redlock_enabled?
          raise BadTimeout, "Timeout must be provided (in milliseconds)" if timeout.nil?
          raise BadTimeout, "Timeout must be at least #{MinTimeoutAllowed / 1_000} seconds" if timeout < MinTimeoutAllowed
          raise BadTimeout, "Timeout must be at most #{MaxTimeoutAllowed / 1_000} seconds" if timeout > MaxTimeoutAllowed

          redlock_client.lock(lock_name, timeout)
        else
          !!session_store.add?(lock_name)
        end
      end

      def release_lock(lock_name)
        if redlock_enabled?
          redlock_client.unlock(lock_name)
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

      def redlock_enabled?
        @redlock_enabled ||= !ENV.fetch("REDIS_URL", "").empty?
      end

      def redlock_client
        @redlock_client ||= Redlock::Client.new([ ENV["REDIS_TLS_URL"] ]) if redlock_enabled?
      end
    end
  end
end

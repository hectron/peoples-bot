require "set"

module BeachSand
  class SessionManager
    class << self
      def acquire_lock(lock_name)
        !!session_store.add?(lock_name)
      end

      def release_lock(lock_name)
        !!session_store.delete?(lock_name)
      end

      def release_all!
        !!session_store.clear
      end

      private

      def session_store
        @session_store ||= Set.new([])
      end
    end
  end
end

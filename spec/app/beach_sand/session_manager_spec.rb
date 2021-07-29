describe BeachSand::SessionManager do
  before do
    BeachSand::SessionManager.release_all!
  end

  describe ".acquire_lock" do
    it "returns true if it adds a lock that doesn't exist" do
      expect(BeachSand::SessionManager.acquire_lock("123")).to eq(true)
    end

    it "returns false if it adds a lock that already exists" do
      expect(BeachSand::SessionManager.acquire_lock("123")).to eq(true)
      expect(BeachSand::SessionManager.acquire_lock("123")).to eq(false)
    end
  end

  describe ".release_lock" do
    it "return false if the lock doesn't exist" do
      expect(BeachSand::SessionManager.release_lock("123")).to eq(false)
    end

    it "return true if the lock exists and is removed" do
      BeachSand::SessionManager.acquire_lock("123")
      expect(BeachSand::SessionManager.release_lock("123")).to eq(true)
      expect(BeachSand::SessionManager.release_lock("123")).to eq(false)
    end
  end

  describe ".release_all!" do
    it "deletes all locks" do
      locks = %w(one two three four)

      locks.each do |lock|
        expect(BeachSand::SessionManager.acquire_lock(lock)).to eq(true)
        expect(BeachSand::SessionManager.acquire_lock(lock)).to eq(false)
      end

      BeachSand::SessionManager.release_all!

      locks.each do |lock|
        expect(BeachSand::SessionManager.release_lock(lock)).to eq(false)
      end
    end
  end
end

describe Commands::BeachSand::SessionManager do
  before do
    described_class.release_all!
  end

  context "without redis" do
    before do
      stub_env("REDIS_URL", "")
    end

    describe ".acquire_lock" do
      it "returns true if it adds a lock that doesn't exist" do
        expect(described_class.acquire_lock("123")).to eq(true)
      end

      it "returns false if it adds a lock that already exists" do
        expect(described_class.acquire_lock("123")).to eq(true)
        expect(described_class.acquire_lock("123")).to eq(false)
      end
    end

    describe ".release_lock" do
      it "return false if the lock doesn't exist" do
        expect(described_class.release_lock("123")).to eq(false)
      end

      it "return true if the lock exists and is removed" do
        described_class.acquire_lock("123")
        expect(described_class.release_lock("123")).to eq(true)
        expect(described_class.release_lock("123")).to eq(false)
      end
    end

    describe ".release_all!" do
      it "deletes all locks" do
        locks = %w[one two three four]

        locks.each do |lock|
          expect(described_class.acquire_lock(lock)).to eq(true)
          expect(described_class.acquire_lock(lock)).to eq(false)
        end

        described_class.release_all!

        locks.each do |lock|
          expect(described_class.release_lock(lock)).to eq(false)
        end
      end
    end
  end

  context "with redis" do
    describe ".acquire_lock" do
      it "returns true if it adds a lock that doesn't exist" do
        expect(described_class.acquire_lock("lock", timeout: 60)).to eq(true)
      end

      it "returns false if it adds a lock that already exists" do
        expect(described_class.acquire_lock("newer_lock", timeout: 60)).to eq(true)
        expect(described_class.acquire_lock("newer_lock", timeout: 60)).to eq(false)
      end
    end

    describe ".release_lock" do
      it "return false if the lock doesn't exist" do
        expect(described_class.release_lock("deleted_lock")).to eq(false)
      end

      it "return true if the lock exists and is removed" do
        described_class.acquire_lock("deletable_lock", timeout: 60)
        expect(described_class.release_lock("deletable_lock")).to eq(true)
        expect(described_class.release_lock("deletable_lock")).to eq(false)
      end
    end

    describe ".release_all!" do
      it "deletes all locks" do
        locks = %w[one two three four]

        locks.each do |lock|
          expect(described_class.acquire_lock(lock, timeout: 60)).to eq(true)
          expect(described_class.acquire_lock(lock, timeout: 60)).to eq(false)
        end

        described_class.release_all!

        locks.each do |lock|
          expect(described_class.release_lock(lock)).to eq(false)
        end
      end
    end
  end
end

describe BobLog do
  let(:mock_io) { StringIO.new }

  before do
    BobLog.configure do |logger|
      logger.device = mock_io
      logger.level = ::Logger::DEBUG
    end
  end

  describe "delegated methods" do
    it "debugs" do
      BobLog.debug("foo")

      expect(mock_io.string).to match(
        a_string_including("DEBUG", "foo")
      )
    end

    it "infos" do
      BobLog.info("foo")

      expect(mock_io.string).to match(
        a_string_including("INFO", "foo")
      )
    end

    it "warns" do
      BobLog.warn("foo")

      expect(mock_io.string).to match(
        a_string_including("WARN", "foo")
      )
    end

    it "errors" do
      BobLog.error("foo")

      expect(mock_io.string).to match(
        a_string_including("ERROR", "foo")
      )
    end
  end
end

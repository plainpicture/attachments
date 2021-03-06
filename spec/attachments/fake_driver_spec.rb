
require File.expand_path("../../spec_helper", __FILE__)

RSpec.describe Attachments::FakeDriver do
  let(:driver) { Attachments::FakeDriver.new }

  it "should list objects" do
    begin
      driver.store("object1", "blob", "bucket1")
      driver.store("object2", "blob", "bucket1")
      driver.store("other", "blob", "bucket1")
      driver.store("object", "blob", "bucket3")

      expect(driver.list("bucket1", prefix: "object").to_a).to eq(["object1", "object2"])
    ensure
      driver.flush
    end
  end

  it "should store a blob" do
    begin
      driver.store("name", "blob", "bucket")

      expect(driver.exists?("name", "bucket")).to be(true)
      expect(driver.value("name", "bucket")).to eq("blob")
    ensure
      driver.flush
    end
  end

  it "should store a blob via multipart upload" do
    begin
      driver.store_multipart("name", "bucket") do |upload|
        upload.upload_part("chunk1")
        upload.upload_part("chunk2")
      end

      expect(driver.exists?("name", "bucket")).to be(true)
      expect(driver.value("name", "bucket")).to eq("chunk1chunk2")
    ensure
      driver.flush
    end
  end

  it "should delete a blob" do
    begin
      driver.store("name", "blob", "bucket")
      expect(driver.exists?("name", "bucket")).to be(true)

      driver.delete("name", "bucket")
      expect(driver.exists?("name", "bucket")).to be(false)
    ensure
      driver.flush
    end
  end

  it "should generate a temp_url" do
    expect(driver.temp_url("name", "bucket")).to eq("https://example.com/bucket/name?signature=signature&expires=expires")
  end
end


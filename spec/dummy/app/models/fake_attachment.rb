# It's fake
class FakeAttachment < ActiveRecord::Base
  belongs_to :fake_attachmentable, polymorphic: true

  def file
    File.read('spec/testfile.txt')
  end

  def filename
    'testfile.txt'
  end
end

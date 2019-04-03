require 'spec_helper'

RSpec.describe BrocadeAPIClient do
  it 'has a version number' do
    expect(BrocadeAPIClient::VERSION).not_to be nil
  end
end

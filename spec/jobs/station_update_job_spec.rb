require 'rails_helper'

RSpec.describe StationUpdateJob, type: :job do
  it "uses the default queue" do
    expect(StationUpdateJob.queue_name).to eq('default')
  end

  it "calls Station.update_data" do
    expect(Station).to receive(:update_data).once
    StationUpdateJob.perform_now
  end
end

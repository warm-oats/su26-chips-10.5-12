# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  city       :string
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  state      :string
#  street     :string
#  title      :string
#  zip        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

RSpec.describe Representative do
  describe ".civic_api_to_representative_params" do
    before(:each) do
      @rep_res = Representative.create({ name: "Donald Beyer", ocdid: "412345",
      title: "representative", party: "Democrat", photo_url: "https://www.congress.gov/img/member/b001292_200.jpg" })

      allow(Representative).to receive(:find_rep).and_return(@rep_res)
      @rep_info = JSON.parse(File.read("./spec/api_json_dump.json"))
    end
    it "should return array containing rep objects" do
      result = Representative.civic_api_to_representative_params(@rep_info)

      expect(result).to eq([@rep_res])
    end
    it "should return empty array when given no data" do
      result = Representative.civic_api_to_representative_params([])

      expect(result).to eq([])
    end
    it "should call .find_rep with the right arguments" do
    end
  end
end

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
      @rep_res = Representative.create({ name: "Donald Beyer", ocdid: "412657",
      title: "representative" })

      @rep_info = JSON.parse(File.read("spec/geocodio_api_call_dump.json"))
      @official = @rep_info['results'][0]['fields']['congressional_districts'][0]['current_legislators'][0]

      allow(Representative).to receive(:find_rep).and_return(@rep_res)
      @result = Representative.civic_api_to_representative_params(@rep_info)
    end
    it "should return array containing rep object" do
      expect(@result).to eq([@rep_res])
    end
    it "should return empty array when given no data" do
      result_empty = Representative.civic_api_to_representative_params([])
      expect(result_empty).to be_empty
    end
    it "should call .find_rep with the right arguments" do
      expect(Representative).to receive(:find_rep).with(
        @official, 
        title: "representative",
        ocdid: "412657"
      )
      result = Representative.civic_api_to_representative_params(@rep_info)
    end
    it "should return array containing rep object with correct values" do
      rep = @result[0]
      expect(rep.name).to eq("Donald Beyer")
      expect(rep.ocdid).to eq("412657")
      expect(rep.title).to eq("representative")
    end
    it "should not return empty array when given valid arguments" do
      expect(@result).not_to be_empty
    end
  end
end

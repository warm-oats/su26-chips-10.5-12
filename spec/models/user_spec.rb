# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  first_name :string
#  last_name  :string
#  provider   :integer          not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_uid_provider  (uid,provider) UNIQUE
#
require 'rails_helper'

RSpec.describe User do
  describe '#name' do
    it 'joins the first and last name' do
      user = described_class.new(first_name: 'Ada', last_name: 'Lovelace')

      expect(user.name).to eq('Ada Lovelace')
    end
  end

  describe '#auth_provider' do
    it 'returns the display name for each provider' do
      expect(described_class.new(provider: :google_oauth2).auth_provider).to eq('Google')
      expect(described_class.new(provider: :github).auth_provider).to eq('GitHub')
      expect(described_class.new(provider: :developer).auth_provider).to eq('Developer')
    end
  end

  describe '.find_google_user' do
    it 'finds users by google uid' do
      user = described_class.create!(uid: 'google-uid', provider: :google_oauth2)

      expect(described_class.find_google_user('google-uid')).to eq(user)
    end
  end

  describe '.find_github_user' do
    it 'finds users by github uid' do
      user = described_class.create!(uid: 'github-uid', provider: :github)

      expect(described_class.find_github_user('github-uid')).to eq(user)
    end
  end
end

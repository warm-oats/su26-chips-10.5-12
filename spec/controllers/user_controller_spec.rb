# frozen_string_literal: true

#
# == Schema Information
#
# Table name: counties
#
#   provider      :integer             not null
#   uid           :string              not null
#   email         :string
#   first_name    :string
#   last_name     :string
#   created_at    :datetime            not null
#   updated_at    :datetime            not null
#   index ["uid", "provider"], name: "index_users_on_uid_provider", unique: true

require 'rails_helper'

RSpec.describe UserController do
  describe 'GET profile' do
    before do
      @user = User.create!(uid: '1', provider: :github)
      session[:user_id] = @user.id
      get :profile
    end

    it 'assigns the correct user' do
      expect(assigns(:user)).to eq(@user)
    end

    it 'renders user profile' do
      expect(response).to render_template(:profile)
    end

    it 'accepts and returns good response' do
      expect(response).to be_successful
    end

    it 'redirects to login page if user not logged in' do
      session[:user_id] = nil
      get :profile

      expect(response).to redirect_to(login_path)
    end

    it 'redirects to login page if user id is invalid' do
      session[:user_id] = -12_345
      get :profile

      expect(response).to redirect_to(login_path)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::UsersController do
  context '#authorize_admin' do
    let(:user) { create(:user) }
    let(:test_user) { create(:user) }

    before do
      allow(controller).to receive_messages spree_current_user: user
      allow(Spree::User).to receive(:find).with(test_user.id.to_s).and_return(test_user)
    end

    it 'should grant access to users with an admin role' do
      user.update!(admin: true)
      spree_post :index
      expect(response).to render_template :index
    end

    it "allows admins to update a user's show api key view" do
      user.update!(admin: true)
      spree_put :update, id: test_user.id, user: { show_api_key_view: true }
      expect(response).to redirect_to spree.edit_admin_user_path(test_user)
    end

    it "re-renders the edit form if error" do
      user.update!(admin: true)
      spree_put :update, id: test_user.id, user: { password: "blah", password_confirmation: "" }

      expect(response).to render_template :edit
    end

    it 'should deny access to users without an admin role' do
      allow(user).to receive_messages admin?: false
      spree_post :index
      expect(response).to redirect_to('/unauthorized')
    end
  end
end

module Users
  class RegistrationsController < Devise::RegistrationsController
    prepend_before_action :reject_guest, only: [:edit, :update, :destroy]

    private

    def reject_guest
      head :forbidden if current_user&.guest?
    end
  end
end

class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authorize
  skip_before_action :authorize, only: [:create]

  def create
    user = User.create(user_params)
    if user.valid?
      session[:user_id] = user.id
      render json: user
    else
      render json: {
               errors: user.errors.full_messages
             },
             status: :unprocessable_entity
    end
  end

  def show
    user = User.find_by(id: session[:user_id])
    render json: user if user
  end

  private

  def user_params
    params.permit(:username, :password, :password_confirmation)
  end

  def authorize
    unless session.include? :user_id
      return render json: { error: "Not authorized" }, status: :unauthorized
    end
  end

  def record_not_found
    render json: { error: "User not found" }, status: :not_found
  end
end

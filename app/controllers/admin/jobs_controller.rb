# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class JobsController < BaseController
    skip_load_and_authorize_resource

    def index
      @jobs = Job.order(id: :desc).page(params[:page]).per(30)
    end

    def trigger
      Job.trigger_compactor
      redirect_to admin_jobs_path
    rescue StandartError => e
      flash[:alert] = 'Cannot create trigger. Try again later'
      render :show
    end
  end
end

class TeachersController < ApplicationController
  before_action :set_organization

  def index
    authorize! :teach, @organization
    @teachers = @organization.teachers
    add_organization_breadcrumb
    add_breadcrumb 'Teachers list'
  end

  def new
    authorize! :teach, @organization
    @teachership = Teachership.new
    add_organization_breadcrumb
    add_breadcrumb 'Teachers list', organization_teachers_path(@organization)
    add_breadcrumb 'Add a new teacher'
  end

  def create
    authorize! :teach, @organization

    user = User.find_by(login: teacher_params[:username])
    @teachership = Teachership.new(user: user, organization: @organization)

    if @teachership.save
      redirect_to organization_teachers_path, notice: 'Teacher added to organization'
    else
      render :new
    end
  end

  def destroy
    authorize! :remove_teacher, @organization
    @teachership = Teachership.find(params[:id])
    @teachership.destroy!
    redirect_to organization_teachers_path ,notice: 'Teacher removed from organization'
  end

  private

  def set_organization
    @organization = Organization.find_by(slug: params[:organization_id])
  end

  def teacher_params
    params.permit(:username)
  end
end

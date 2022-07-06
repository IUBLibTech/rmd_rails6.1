class UserController < ApplicationController

  def ldap_lookup
    @user = User.ldap_lookup
  end

  def index
    @users = User.all
  end

  def ajax_set_user_unit
    @user = User.where(username: params[:username]).first
    begin
      @user[params[:unit].to_sym] = true?(params[:access])
      @user.save!
      render json: {msg: "#{@user.username} access to #{params[:unit]} updated!", access: true?(params[:access])}
    rescue => error
      puts error.backtrace
      render json: {errors: @user.errors.full_messages}, status: 500
    end
  end

  def ajax_toggle_cl
    if (User::WEB_ADMINS.include?(User.current_username))
      begin
        cl = false
        if User::COPYRIGHT_LIBRARIANS.include?(params[:username])
          User::COPYRIGHT_LIBRARIANS.delete(params[:username])
          puts "Deleting #{params[:username]} from CL list"
        else
          User::COPYRIGHT_LIBRARIANS << params[:username]
          puts "Adding  #{params[:username]} to CL list"
          cl = true
        end
        render json: {msg: "#{params[:username]} has been #{cl ? "added to" : "removed from"} the copyright librarians list", username: params[:username], cl: cl}
      rescue => error
        puts error.message
        puts error.backtrace
        render json: {errors: @user.errors.full_messages}, status: 500
      end
    end
  end

  def show

  end

  def ajax_set_user_ignore_ads

  end

end

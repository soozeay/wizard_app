# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(sign_up_params)
     unless @user.valid?
       render :new and return
       # returnは下記の[ render :new_address ] を読み込んでしまう、[ DoubleRenderError ]を防ぐ為に記述
     end
    session["devise.regist_data"] = {user: @user.attributes}
    # attributesメソッドはインスタンスメソッドから取得できる値をオブジェクト型からハッシュ型に変換できるメソッド
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    # attributesメソッドでデータ整形をした際にパスワードの情報は含まれない。そこで、パスワードを再度sessionに代入する必要がある
    @address = @user.build_address
    # ユーザーモデルに紐づく住所情報を入力させるため、該当するインスタンスを生成しておく必要がある。そのために、build_addressで今回生成したインスタンス@userに紐づくAddressモデルのインスタンスを生成
    render :new_address
  end

  def create_address
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Address.new(address_params)
     unless @address.valid?
       render :new_address and return
     end
    @user.build_address(@address.attributes) # バリデーションチェックが完了した情報とsessionで保持していた情報を合わせ、ユーザー情報として保存
    @user.save
     # build_addressを用いて送られてきたparamsを、保持していたsessionが含まれる@userに代入。そしてsaveメソッドを用いてテーブルに保存
    session["devise.regist_data"]["user"].clear
    sign_in(:user, @user)
    # ユーザーの新規登録ができても、ログインができているわけではない。それをsign_inメソッドを利用してログイン作業を行う 
  end

  private

 def address_params
   params.require(:address).permit(:postal_code, :address)
 end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end

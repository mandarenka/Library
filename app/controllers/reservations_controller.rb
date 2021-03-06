class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]
  before_action :set_books, only: [:new, :edit, :update, :create, :show]
  before_action :set_users, only: [:new, :edit, :update, :create]
  before_action :authenticate_user! , expect: [:new, :show, :edit, :create, :update, :destroy]
  # GET /reservations
  # GET /reservations.json
  def index
   @user = current_user
   @reservations = current_user.reservations
 end

  # GET /reservations/1
  # GET /reservations/1.json
  def show
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations
  # POST /reservations.json
  def create
    @reservation = Reservation.new(reservation_params)
    book=Book.find_by_id(reservation_params[:book_id])

    @reservation.date = Time.zone.now + 10.minute
    @reservation.user = current_user
    
    
    respond_to do |format|
      
     if @reservation.save
       format.html { redirect_to @reservation, notice: 'Reservation was succesfully created.' }
       format.json { render action: 'show', status: :created, location: @reservation }
     elsif @reservation.save
      UserMailer.reminder(@reservation.user, @reservation.date, @reservation.book.title).deliver
      format.html { redirect_to @reservation, notice: @reservation.user.email + ' Reservation was successfully created.' }          
      format.json { render action: 'show', status: :created, location: @reservation }
    else
      format.html { render action: 'new' }
      format.json { render json: @reservation.errors, status: :unprocessable_entity }
    end
  end
end

  # PATCH/PUT /reservations/1
  # PATCH/PUT /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
        format.html { redirect_to @reservation, notice: 'Reservation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1
  # DELETE /reservations/1.json
  def destroy
    @reservation.destroy
    respond_to do |format|
      format.html { redirect_to reservations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reservation_params
      params.require(:reservation).permit(:book_id, :user_id, :date)
    end
    
    def is_reserved(book)
      book= Reservation.find_by_book_id(book.id)
      if book != nil
        return true
      else
        return false
      end
    end
    
    def set_books
     @books = Book.find(:all).map do |book|
       [ book.title, book.id ]
     end
   end
   
   def set_users
     @users = User.find(:all).map do |user|
       [ user.id, user.email ]
     end
   end
 end

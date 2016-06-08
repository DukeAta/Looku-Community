
class DocumentsController < ApplicationController
  require 'net/http'
  before_action :authenticate_user!, except: [:index]
  autocomplete :document, :title, :full => true

  def index
    if params[:category]
      @documents = Document.where(category: params[:category]).page params[:page]
    elsif params[:title]
      @documents = Document.where(title: params[:title]).page params[:page]
    elsif params[:is_verified]
      @documents = Document.where(is_verified: eval(params[:is_verified])).page params[:page]
    elsif params[:favorite]
      documents = Vote.where(user_id: current_user).map(&:document)
      @documents = Kaminari.paginate_array(documents).page params[:page]
    elsif params[:rating]
      document_ids = Rate.where(stars: (params[:rating].to_i)..(params[:rating].to_i+1)).map(&:rateable_id)
      documents = Document.where(id: document_ids)
      @documents = Kaminari.paginate_array(documents).page params[:page]
    elsif params[:search]
      documents = Document.search(params[:search])
      @documents = Kaminari.paginate_array(documents).page params[:page]
    else
      if current_user.present?
        @documents = Document.page params[:page]
      else
        @documents = Document.page(params[:page]).per(4)
      end
    end
  end

  def upload
  end

  def edit
    @document = Document.find(params[:id])

    respond_to do |format|
      if current_user.id == @document.user_id
        format.html
      else
        format.html { redirect_to root_path }
      end
    end

  end


  def create
    @document = current_user.documents.new(document_params)

    respond_to do |format|
      if @document.save
        DocumentMailer.upload_success(current_user, @document).deliver_now
        format.html { redirect_to user_documents_path(current_user), 
          :flash => { :alert => "Success! Your document is now under review. Once successfully reviewed, you will get paid every time this document is viewed and referenced." } }
        format.json { render json: {message: "success", documentID: @document.id }, :status => 200 }
      else
        format.html { redirect_to root_path, :flash => { :error => "Errors!"  } }
        format.json { render json: { error: @document.errors.full_messages.join(',')}, :status => 400 }
      end
    end
  end

  def update
    @document = Document.find(params[:id])

    respond_to do |format|
      if @document.update_attributes(document_params)
        format.html { redirect_to user_documents_path }
        format.json { render json: {message: "success", documentID: @document.id }, :status => 200 }
      else
        format.html { redirect_to user_documents_path, :flash => { :error => "Errors!"  } }
        format.json { render json: { error: @document.errors.full_messages.join(',')}, :status => 400 }
      end
    end
  end

  def show
    @document = Document.find(params[:id])
    count_pages @document
    @current_purchased = Purchase.where(document_id: @document.id, user_id: current_user.id).first
    @is_purchased = @current_purchased.present? && @current_purchased.completed? &&
      @current_purchased.calculate_days_of_purcharse <=
      Document.find(@current_purchased.document_id).life_time_category
    @comments = @document.comments.order("created_at DESC")
    @comment = Comment.new
    @purchase = Purchase.new
    @voted = Vote.find_by(user_id: current_user, document_id: @document)
    @rating = Rate.find_by(rater_id: current_user, rateable_id: @document, dimension: "document")
  end

  def download
    @document = Document.find(params[:id])
    if @document.blank?
      redirect_to root_path and return
    end
    purchased = Purchase.where(document_id: @document.id, user_id: current_user.id).first
    @is_purchased = purchased.present?

    if purchased.blank?
      redirect_to root_path and return
    end

    unless purchased.calculate_days_of_purcharse <= @document.life_time_category
      redirect_to root_path and return
    end

    #if @document.user_id != current_user.id && !@is_purchased
    #  Purchase.create(user: current_user, document: @document) if @document.user_id != current_user.id
    #end

    send_data @document.file.read, filename: @document.title

  end

  private
  def document_params
    params.require(:document).permit(
      :file, :title, :score, :university, :institution, :country, :level,
      :year, :word_count, :category, :price, :preview_page, :resource_type, :document_type
    )
  end

  def count_pages document
    unless document.total_pages
      io = open(document.file_url)
      reader = PDF::Reader.new io
      total_pages = reader.page_count
      document.update_attributes total_pages: total_pages
    end
  end
end

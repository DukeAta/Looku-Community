class CommentsController < ApplicationController
  before_action :authenticate_user!
  def create
    @comment = Comment.create(comment_params)
    respond_to do |format|
      format.js
      format.json { render json: {message: "success", commentID: @comment.id }, :status => 200 }
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:content, :user_id, :document_id)
  end
end

class VotesController < ApplicationController
  def create
    Vote.create vote_params
  end

  private
  def vote_params
    params.require(:vote).permit :user_id, :document_id
  end
end

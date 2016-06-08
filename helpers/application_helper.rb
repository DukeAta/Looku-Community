module ApplicationHelper
  def rating_doc document
    Rate.find_by(rater_id: current_user, rateable_id: document, dimension: "document")
  end

  def count_doc_rating stars
    document_ids = RatingCache.where(avg: ((stars)..stars+1)).map(&:cacheable_id)
    Document.where(id: document_ids).size
  end

  def facebook_shares(url)
    data = Net::HTTP.get(URI.parse("http://graph.facebook.com/?ids=#{URI.escape(url)}"))
    data = JSON.parse(data)
    data[url]['shares']
  end

  def active_class(link_path)
  current_page?(link_path) ? "active" : ""
  end

end

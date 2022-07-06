class AtomFeedRead < ApplicationRecord

  def mco_id
    # converts the avalon_id from JSON which is actually a URL like https://mco-staging.dlib.indiana.edu/media_objects/gb19f9998
    # into just the ID portion of the URL: gb19f9998 in this case
    avalon_id.chars[avalon_id.rindex('/')+1..avalon_id.length].join("")
  end


end

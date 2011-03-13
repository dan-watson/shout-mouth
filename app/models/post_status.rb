class PostStatus

  #Factory Methods
  def self.statuses
    {
      :publish => "Published",
      :draft => "Draft"
    }
  end

  def self.boolean_from_status(status)
    case
    when status == "publish"
      true
    else
      false
    end
  end

  def self.status_from_boolean(active)
    active ? "publish" : "draft"
  end

end

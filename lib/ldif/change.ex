defprotocol LDIF.Change do

  @moduledoc false
  
  def apply_to_entry(change, entry)
end

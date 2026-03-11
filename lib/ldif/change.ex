defprotocol LDIF.Change do
  def apply_to_entry(change, entry)
end

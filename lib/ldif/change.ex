defprotocol LDIF.Change do
  def apply(change, entry)
end

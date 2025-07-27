{
  enable = true;
  notifications.mail = {
    sender = "morpheus@lyndeno.ca";
    recipient = "lsanche@lyndeno.ca";
    enable = true;
  };
  # Short self test every week at 2AM
  # Long self test every month on the 5th at 4AM
  #defaults.monitored = "-a -o on -s (S/../../7/02|L/../05/../04)";
}

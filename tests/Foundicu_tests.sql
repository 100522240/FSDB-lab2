--Test the first error, when the user is not in the database
exec foundicu.set_current_user(user);
exec foundicu.insert_loan('RI645');

--Now provide a valid user
exec foundicu.set_current_user()
--Check for the second error, when there are no copies available

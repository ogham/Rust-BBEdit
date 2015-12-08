tell application "BBEdit"
	tell front text document
		if modified = true then
			save its document
		end if
		set the_file to its file
		if the_file ­ missing value then
			set the_path to POSIX path of ((the_file as text) & "::")
		else
			error "Document does not point to a file"
		end if
	end tell
end tell

tell application "Terminal"
	do script "cd " & (quoted form of the_path) & "; cargo test"
end tell

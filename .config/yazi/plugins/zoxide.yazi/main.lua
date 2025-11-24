return {
	entry = function()
		local child = ya.child("zoxide"):arg("query"):arg("--interactive")
		local output = child:wait()
		if output and output.status.success then
			local path = output.stdout:gsub("\n$", "")
			if path ~= "" then
				ya.emit("cd", { path })
			end
		end
	end
}
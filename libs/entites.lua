function SetFrame(en, frame)
	
	local frame_num = frame

	if frame_num == 999 or frame_num == 0 then 
		if en.idle_frame ~= 0 then
			frame_num = en.idle_frame
		else
			for i = 1, #en.frames do
				if en.frames[i] ~= nil then
					frame_num = i
					break
				end
			end
		end
	end

	if en.frames[frame_num] ~= nil then
		en.frame = frame_num
		local frame = GetFrame(en)
		en.wait = frame.wait
		en.next_frame = frame.next
	end
end
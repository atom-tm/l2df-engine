function SetFrame(en, frame_num)
	en.frame = frame_num
	local frame = GetFrame(en)
	en.wait = frame.wait
	en.next_frame = frame.next
end
function Gravity(en_id) -- отвечает за гравитацию, иннерцию и скорость персонажа по всем осям. функция не выполняет перемещение, а лишь высчитывает поведение скоростей исходя из всех факторов.
-------------------------------------

end


function Motion(en, dt)

end

function BordersCheck(en)
	if en.y < 0 then en.y = 0 end
	if en.y > map.border_up then en.y = map.border_up end
	if en.z < 0 then en.z = 0 end
	if en.z > map.area then en.z = map.area end
	if en.x < 0 then en.x = 0 end
	if en.x > map.width then en.x = map.width end
end
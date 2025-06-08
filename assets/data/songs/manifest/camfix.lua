local cameras = {'camGame', 'camHUD'}

function onUpdatePost(dt)
	for _,camera in ipairs(cameras) do
		setProperty(camera .. ".flashSprite.scaleX", 2)
		setProperty(camera .. ".flashSprite.scaleY", 2)

		local scale = getProperty(camera .. ".zoom") / 2
		callMethod(camera .. ".setScale", {scale, scale})
	end
end
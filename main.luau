--This is a Chat command's handler script,This script is only made to be a demo, that's why its usefulness is questionable
local Debris = game:GetService("Debris") -- Defines Debris serv.
local DS = game:GetService("DataStoreService")
local TS = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local DataStoreMain = DS:GetDataStore("Main") -- Imports a data store
local REvents = game.ReplicatedStorage.RemoteEvents
local Commands = {} --Main Commands Table
local AnimInstance = Instance.new("Animation") -- make new anim instance
AnimInstance.AnimationId = "rbxassetid://106938228468653" -- Set to a waving animation
AnimInstance.Parent = workspace
local function SendServerResponse(plr,txt)
	REvents.ServerMessage:FireClient(plr,txt) -- Send server reply, to a simple local script, for some functions
end
Commands.die = function(plr) -- Command that kills the player
	plr.Character.Humanoid.Health = 0 -- Set Health to 0
end
Commands.grav = function(plr,arg)
	if not tonumber(arg) or tonumber(arg)<=0 then -- Make sure its a number and a postive one (you cannot have negative gravity)
		return
	end
	workspace.Gravity = arg
end
Commands.teleport = function(plr,arg)  -- teleport player in random place, the argument is how far they will teleport from themselfs
	if not tonumber(arg) then
		return
	end
	plr.Character:PivotTo(plr.Character.HumanoidRootPart.CFrame + Vector3.new(math.random(arg*-1,arg),0,math.random(arg*-1,arg)))
end
Commands.run = function(plr) -- Command that makes the player move forward, with a LinearVelocity
	local rpart = plr.Character.HumanoidRootPart -- for code's lenght sake
	local Veloc = Instance.new("LinearVelocity") -- Makes a new LinearVelocity
	local att = rpart.RootAttachment -- FindRootAttachment
	Veloc.Attachment0 = att -- set attachment to a new one inside primpart
	Veloc.MaxForce = math.huge -- not limiting force
	Veloc.VectorVelocity =rpart.CFrame.LookVector * 40 -- So player runs forward
	Veloc.Parent = plr.Character.HumanoidRootPart
	Debris:AddItem(Veloc,2) -- Destroyed after 2 sec
end
Commands.part = function(plr) -- Random color part function
	local Part = Instance.new("Part") -- Spawn part in workspace
	Part.Position = plr.Character.HumanoidRootPart.Position + Vector3.new(0,3,0) -- Set part's position a top of the player
	Part.Color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255)) -- Just For Fun set random color
	Part.Parent = workspace	
end
Commands.savelast = function(plr) -- Command, to showcase simple Data store manipulation
	DataStoreMain:SetAsync("LastVisitor",plr.Name)  -- Save it
end
Commands.displaylast = function(plr)  -- Command to display last saved visitor
	SendServerResponse(plr,DataStoreMain:GetAsync("LastVisitor")) -- read the value and send server message
end
Commands.wave = function(plr) -- command to showcase animation play
	plr.Character.Humanoid.Animator:LoadAnimation(AnimInstance):Play() -- Actually Play it
end
Commands.ragdoll = function(plr) -- command to make the player ragdoll
	for i,joint in plr.Character:GetDescendants() do -- Check all desecandts
		if joint:IsA("Motor6D") then -- To see if its a motor 6
			local socketC = Instance.new("BallSocketConstraint") -- New Socket
			local att0 = Instance.new("Attachment") -- New attachments for the sockets
			local att1 = Instance.new("Attachment")
			att0.CFrame = joint.C0 -- Set attachment's CFrame's to match the existing ones
			att1.CFrame = joint.C1
			att0.Parent = joint.Part0
			att1.Parent = joint.Part1
			socketC.Attachment0 = att0 -- set Sockets attachments to the one's that were just made
			socketC.Attachment1 = att1
			socketC.TwistLimitsEnabled = true -- Set limits so the player dosent fly away 
			socketC.LimitsEnabled = true
			socketC.Parent = joint.Parent
			joint.Enabled = false -- Disable Motor6D
		end
	end
	REvents.SetHumanState:FireClient(plr,Enum.HumanoidStateType.Physics)
end
Commands.meteor = function(plr) -- make meteors that fall at diffrent speeds
	for i=1,20 do		--Loop spawning meteors
		local meteor = Instance.new("Part")
		meteor.Size = Vector3.new(5,5,5) 
		meteor.Color = Color3.fromRGB(255, 149, 0)
		meteor.Material = Enum.Material.SmoothPlastic
		meteor.CFrame = CFrame.new(math.random(-250,250),200,math.random(-250,250)) -- spawn at random positions
		local attach = Instance.new("Attachment") -- Make an attachment
		attach.Parent = meteor
		local Vel = Instance.new("LinearVelocity") -- Make an Linear Velocity
		Vel.Parent = workspace
		Vel.Attachment0 = attach -- Since LineanVelocity requires an Attachment
		Vel.MaxForce = math.huge -- Do not limit max force
		Vel.VectorVelocity = Vector3.new(0, math.random(-125, -75), 0) -- Set Velocity to random 
		local exploded = false -- Value that makes sure it dosent explode more than once
		meteor.Touched:Connect(function() -- make the meteor explode
			if exploded then
				return -- if exploded end the command
			end
			Vel:Destroy() -- destroy velocity, it landed alr
			exploded = true
			local Explosion = Instance.new("Explosion") -- Add an explosion
			Explosion.Position = meteor.Position -- Set its position ot the one of the Meteor's
			Explosion.Parent = workspace
			Debris:AddItem(meteor,2.5) -- Remove with Debris after 4.5 sec
		end) 
		meteor.Parent = workspace
	end
end
local radius = 10 -- set radius
Commands.orbit = function(plr) -- Some math functionality, orbiting balls around player (sin/cos)
	local rpart = plr.Character.HumanoidRootPart -- for code's lenght sake
	local BallTab = {} -- Tables to store balls
	for i=1,5 do -- Loop that spawns 5 balls 
		local Ball = Instance.new("Part") -- spawning Ball to orbit
		Ball.Anchored = true
		Ball.Size = Vector3.new(3,3,3) 
		Ball.Shape = Enum.PartType.Ball -- Make it a Ball
		Ball.Material = Enum.Material.SmoothPlastic -- make it smooth plastic
		Ball.Color = Color3.fromRGB(255, 0, 0)
		Ball.CanCollide = false -- Make the ball not colide so it dosen't act weirdly
		table.insert(BallTab,Ball) -- Insert the Ball to the table
		Debris:AddItem(Ball,7.5)
		Ball.Parent = workspace
	end
	local angle = 0
	while true do -- Parent Loop (not actually infinite)
		for i,Ball in BallTab do
			local AnglePersonal = angle + (( math.pi *2 / #BallTab) * (i - 1)) -- Caluclates the perfect position for the balls
			if not Ball.Parent then
				return -- If ball has been destroyed (Parent is Nil) then stop the loops
			end
			Ball.Position =  Vector3.new(rpart.Position.X + radius*math.cos(AnglePersonal),rpart.Position.Y,rpart.Position.Z + radius*math.sin(AnglePersonal)) -- Calculate the orbit position
		end
		angle += 0.025 -- Increases Angle
		task.wait(0.01)
	end
end
Commands.settime = function(plr,arg) -- A command that sets the time of day
	local DynamicTime = { -- Table with words to times
		["morning"] = 8,
		["noon"] = 12,
		["afternoon"] = 16,
		["evening"]= 19,
		["midnight"] = 0,
		["dawn"] = 6, 
	}
	if DynamicTime[arg] then -- if arguemnt is in the times table
		game.Lighting.TimeOfDay = DynamicTime[arg] -- set time of day to it 
	end
end
Commands.raycast = function(plr) -- Raycast showace (raycast between the floating pink part and players rpart)
	local rpart = plr.Character.HumanoidRootPart -- for code's lenght and readabilty's sake
	local RayParm = RaycastParams.new() -- New ray params
	RayParm.FilterType = Enum.RaycastFilterType.Exclude
	RayParm.FilterDescendantsInstances = {plr.Character,workspace.RayPart} -- Filter out the part it self and the player's rig
	local res = workspace:Raycast(rpart.Position,workspace.RayPart.Position-rpart.Position,RayParm) -- The ray's logic itself
	if res then
		SendServerResponse(plr,"There is "..res.Instance.Name.." found in between those")  -- Respond when results are found
	else
		SendServerResponse(plr,"There is nothing found in between those") -- Response where there is no results
	end
end
Commands.size = function(plr,arg) -- Commands to scale player
	if not tonumber(arg) then -- Makes sures that the  argument is a number
		return 
	end
	if plr.Character.Humanoid.RigType ~= Enum.HumanoidRigType.R15 then -- makes sure that player is R15, if not display the notification
		SendServerResponse(plr,"Size Scaling is exlusive to R15 rigs") -- Send message
		return
	end
	for i,Value in plr.Character.Humanoid:GetChildren() do -- Gets all values inside humanoid
		if Value:IsA("NumberValue") then -- Makes sure its a Number Value (scaling values)
			Value.Value = arg -- Set the value to the argument
		end
	end
end
Commands.followers = function(plr,arg) -- Create an x amount of dummies that dollow you for 15 seconds
	if not tonumber(arg) or tonumber(arg)%1 ~= 0 or tonumber(arg)<=0 then -- Makes sures that the  argument is a number and an Int, positive number
		return 
	end
	local function MakeAFollower() -- Main dummy function
		local Path = PathfindingService:CreatePath()
		local Rig = script.Rig:Clone() -- Preset rig in script (defualt brick rig)
		Rig.Parent = workspace
		Rig:PivotTo(CFrame.new(math.random(-250,250),0,math.random(-250,250))) -- spawn the rig at random locations near spawn point
		local function Follower()
			Path:ComputeAsync(Rig.HumanoidRootPart.Position,plr.Character.HumanoidRootPart.Position) -- Caluclates path between those two
			if #Path:GetWaypoints() >= 3 and Rig.Parent then -- If path has atleast 3 way points
				Rig.Humanoid:MoveTo(Path:GetWaypoints()[3].Position) -- walk to the third one (common PathFinding technique)
			elseif #Path:GetWaypoints() < 3 and plr.Character and Rig.Parent then -- if it has less...
				Rig.Humanoid:MoveTo(plr.Character.HumanoidRootPart.Position) -- walk directly to the player
			end		
		end
		task.spawn(function() -- so the for loop can continue
			while Rig.Parent and plr.Character do -- while loop, that dosent interfere with the rest of the code
				Follower() -- done like that for unnesting purpouses 
				task.wait()
			end
		end)
		Debris:AddItem(Rig,15)
	end
	for i=1,arg do -- loop to spawn exact amout of dummies
		MakeAFollower()
	end
end
Commands.agemeta = function(plr,arg) -- Simple Metatable
	local TableMetaData = {} -- The actual meta table
	local DataPrototype = {
		Age = 21
	}  -- the "Master" table
	TableMetaData.__index = DataPrototype -- Set tables index to the prototype
	local ProperData = {}
	setmetatable(ProperData,TableMetaData) -- Set the metatable to the TableMetaData
	SendServerResponse(plr,"Age data before setting the arg : "..ProperData.Age) -- Display pre set Age
	if tonumber(arg) then -- Make sure the argument is a number, if not then it wont change
		ProperData.Age = arg
	end	
	SendServerResponse(plr,"Age data after setting the arg : "..ProperData.Age) -- Display post set Age
end
Commands.wraptime = function(plr)-- Creates a funny time wrap effect
	local Human = plr.Character.Humanoid -- Defines Huanoid
	local shockwave = Instance.new("Part") -- All part configuration, described in other parts
	shockwave.Shape = Enum.PartType.Ball
	shockwave.CFrame = plr.Character.HumanoidRootPart.CFrame
	shockwave.Color = Color3.fromRGB(255,255,255)
	shockwave.Transparency = 0.5
	shockwave.Size = Vector3.new(0,0,0)
	shockwave.Material = Enum.Material.SmoothPlastic
	shockwave.CanCollide = false
	shockwave.Anchored = true
	shockwave.CastShadow = false
	shockwave.Parent = workspace
	TS:Create(shockwave,TweenInfo.new(5),{Size = Vector3.new(200,200,200),Transparency = 1}):Play() -- Make it grow and become invisible
	local Blur = Instance.new("BlurEffect")
	Blur.Size = 15
	Blur.Parent = game.Lighting
	TS:Create(Blur,TweenInfo.new(5),{Size = 0}):Play()
	Debris:AddItem(shockwave,5)
	Debris:AddItem(Blur,5)
	Human.JumpPower = 75
	workspace.Gravity = 30
	task.wait(8)
	workspace.Gravity = 196.2
	if Human then
		Human.JumpPower = 50
	end
end
game.Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg) -- Event of player sending a message
		msg = string.lower(msg)
		local SplitToArgs = string.split(string.split(msg,"/")[2] or ""," ") -- splits the message
		if plr.Character and msg:match("/") and Commands[SplitToArgs[1]] then -- Makes sure that the message contains / and a such Command exsists (also makes sure player has a character, just to make it easier)
			Commands[SplitToArgs[1]](plr,SplitToArgs[2])
		end
	end)
end)
-- Made by SpaceCow/Corrupted (Sorry for so many comments, i just wanted to make sure it's alright...), please excuse my broken english, I am not native :D

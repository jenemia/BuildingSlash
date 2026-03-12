extends RefCounted
class_name RewardCalculator

static func calculate_reward(survival_sec: float, score: int) -> int:
	var time_reward := int(floor(survival_sec * 0.8))
	var score_reward := int(floor(score * 0.15))
	return maxi(0, time_reward + score_reward)

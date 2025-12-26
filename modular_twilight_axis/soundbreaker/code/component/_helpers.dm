/// util: сорт по длине текста убыв.
/// tg-стиль: отдельный proc, без лямбд.
/proc/cmp_text_length_desc(a, b)
	return length(b) - length(a)

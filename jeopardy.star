load("render.star", "render")
load("animation.star", "animation")
load("http.star", "http")

def get_question():
    #res = http.get("https://raw.githubusercontent.com/abochnak/tidbyt-jeopardy/main/data/questions.json")
    res = http.get("http://127.0.0.1:8787/data/questions.json")
    if res.status_code != 200:
        fail("Failed with status_code %d" % res.status_code)
    questions = res.json()

    return questions[0]

def main(config):
    data = get_question()
    category = data["category"]
    answer = data["answer"]
    response = data["response"]

    return render.Root(
        child = render.Box(
            child = animation.Transformation(
                child = render.Box(
                    color = "#00f",
                    child = render.WrappedText(content="%s" % category, font="tb-8", align="center")
                ),
                duration = 100,
                delay = 0,
                origin = animation.Origin(0, 0),
                keyframes = [
                    animation.Keyframe(
                        percentage = 0.0,
                        transforms = [animation.Scale(0, 0)],
                        curve = "ease_in_out"
                    ),
                    animation.Keyframe(
                        percentage = 1.0,
                        transforms = [animation.Scale(1, 1)],
                        curve = "ease_in_out"
                    )
                ]
            )
        )
    )
load("render.star", "render")
load("animation.star", "animation")
load("encoding/json.star", "json")
load("http.star", "http")
load("cache.star", "cache")
load("random.star", "random")


def get_question():
    if cache.get("jeopardy_question") != None:
        return json.decode(cache.get("jeopardy_question"))

    res = http.get("https://raw.githubusercontent.com/abochnak/tidbyt-jeopardy/main/data/questions.json")
    if res.status_code != 200:
        fail("Failed with status_code %d" % res.status_code)

    questions = res.json()
    question = questions[random.number(0, len(questions))]
    cache.set("jeopardy_question", json.encode(question), ttl_seconds=7200)

    return question

def display_for(duration, child):
    return render.Box(
        child = animation.Transformation(
            child = child,
            duration = duration,
            delay = 0,
            origin = animation.Origin(0, 0),
            direction = "normal",
            fill_mode = "forwards",
            keyframes = [
                animation.Keyframe(
                    percentage = 0.0,
                    transforms = [],
                ),

                animation.Keyframe(
                    percentage = 1.0,
                    transforms = [],
                ),
            ],
        )
    )

def category_section(category):
    return render.Box(
        child = animation.Transformation(
            child = render.Box(
                color = "#00f",
                child = render.WrappedText(
                    content="%s" % category.upper(), 
                    font="tb-8",
                    align="center",
                    linespacing = 0
                )
            ),
            duration = 20,
            delay = 0,
            origin = animation.Origin(0.5, 0.5),
            direction = "normal",
            fill_mode = "forwards",
            keyframes = [
                animation.Keyframe(
                    percentage = 0.0,
                    transforms = [animation.Scale(0.01, 0.01), animation.Translate(2, 2)],
                ),

                animation.Keyframe(
                    percentage = 0.5,
                    transforms = [],
                ),

                animation.Keyframe(
                    percentage = 1.0,
                    transforms = [],
                ),
            ],
        )
    )

def answer_section(answer):
    return render.Box(
        color = "#00f",
        child = render.Marquee(
            height = 32,
            offset_start = 32,
            offset_end = 0,
            child = render.WrappedText(
                content = answer,
                width = 64,
                font="tb-8",
                align="center"
            ),
            scroll_direction = "vertical",
        ),
    )

def what_is_section():
    return render.Box(
        child = render.WrappedText(
            content = "WHAT IS...",
            width = 64,
            font="tb-8",
            align="center"
        ),
    )

def response_section(response, air_date):
    return render.Box(
        color = "#00f",
        child = render.Marquee(
            height = 32,
            offset_start = 32,
            offset_end = 32,
            child = render.WrappedText(
                content = response + "\n \n(" + air_date + ")",
                width = 64,
                font="tb-8",
                align="center"
            ),
            scroll_direction = "vertical",
        ),
    )

def main(config):
    data = get_question()

    part_one = [
        category_section(data["category"]),
        answer_section(data["answer"])
    ]

    part_two = [
        display_for(20, what_is_section()),
        display_for(20, response_section(data["response"], data["air_date"]))
    ]

    return render.Root(
        delay = 100,
        show_full_animation = True,
        child = render.Sequence(
            children = part_one + part_two if config.bool("show_all") else (
                part_one if not config.bool("show_response") else part_two
            )
        )
    )
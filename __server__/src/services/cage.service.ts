import { getEnv } from "../_core/config/env.config";

export const findCageLimitByTitle = (title: string):number => {
    const env = {
        MAX_LIMIT_SMALL_CAGE: Number(process.env.MAX_LIMIT_SMALL_CAGE),
        MAX_LIMIT_MEDIUM_CAGE: Number(process.env.MAX_LIMIT_MEDIUM_CAGE),
        MAX_LIMIT_LARGE_CAGE: Number(process.env.MAX_LIMIT_LARGE_CAGE),
    };
    if(title.toLowerCase() === "small") {
        return env.MAX_LIMIT_SMALL_CAGE!;
    }
    if(title.toLowerCase() === "medium") {
        return env.MAX_LIMIT_MEDIUM_CAGE!;
    }
    if(title.toLowerCase() === "large") {
        return env.MAX_LIMIT_LARGE_CAGE!;
    }
    return 0;
}
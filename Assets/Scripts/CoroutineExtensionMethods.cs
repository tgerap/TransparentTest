using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public static class CoroutineExtensionMethods
{
    public static Coroutine Start(this IEnumerator coroutine, MonoBehaviour bevaviour)
    {
        return bevaviour.StartCoroutine(coroutine);
    }

    public static void Stop(this Coroutine coroutine, MonoBehaviour behaviour)
    {
        if (behaviour == null)
            return;

        if (coroutine == null)
            return;

        behaviour.StopCoroutine(coroutine);
    }
}
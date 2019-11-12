﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class PostProcessing : MonoBehaviour
{
    public Material material;

    private void Update()
    {
       Vector3 pos = Camera.main.ScreenToViewportPoint(Input.mousePosition);
        material.SetVector("_MousePos", pos);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination,material);
    }
}

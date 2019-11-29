using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestOverlap : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Collider2D[] colliders = Physics2D.OverlapCircleAll(transform.position, 2);

    }
}
